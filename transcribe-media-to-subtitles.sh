#!/usr/bin/env bash
# Transcribe all input media's speech to subtitle files
#
# Copyright 2024 林博仁(Buo-ren Lin) <buo.ren.lin@gmail.com>
# SPDX-License-Identifier: AGPL-3.0-or-later

GGML_MODEL="${GGML_MODEL:-ggml-medium.bin}"
TRANSCRIBE_THREADS="${TRANSCRIBE_THREADS:-auto}"
TRANSCRIBE_THREADS_NEGATIVE_OFFSET="${TRANSCRIBE_THREADS_NEGATIVE_OFFSET:-1}"

printf \
    'Info: Configuring the defensive interpreter behaviors...\n'
set_opts=(
    # Terminate script execution when an unhandled error occurs
    -o errexit
    -o errtrace

    # Terminate script execution when an unset parameter variable is
    # referenced
    -o nounset
)
if ! set "${set_opts[@]}"; then
    printf \
        'Error: Unable to configure the defensive interpreter behaviors.\n' \
        1>&2
    exit 1
fi

printf \
    'Info: Checking the existence of the required commands...\n'
required_commands=(
    ffmpeg
    nproc
    realpath
    whisper-cpp.main
)
flag_required_command_check_failed=false
for command in "${required_commands[@]}"; do
    if ! command -v "${command}" >/dev/null; then
        flag_required_command_check_failed=true
        printf \
            'Error: This program requires the "%s" command to be available in your command search PATHs.\n' \
            "${command}" \
            1>&2
    fi
done
if test "${flag_required_command_check_failed}" == true; then
    printf \
        'Error: Required command check failed, please check your installation.\n' \
        1>&2
    exit 1
fi

printf \
    'Info: Configuring the convenience variables...\n'
if test -v BASH_SOURCE; then
    # Convenience variables may not need to be referenced
    # shellcheck disable=SC2034
    {
        printf \
            'Info: Determining the absolute path of the program...\n'
        if ! script="$(
            realpath \
                --strip \
                "${BASH_SOURCE[0]}"
            )"; then
            printf \
                'Error: Unable to determine the absolute path of the program.\n' \
                1>&2
            exit 1
        fi
        script_dir="${script%/*}"
        script_filename="${script##*/}"
        script_name="${script_filename%%.*}"
    }
fi
# Convenience variables may not need to be referenced
# shellcheck disable=SC2034
{
    script_basecommand="${0}"
    script_args=("${@}")
}

printf \
    'Info: Setting the ERR trap...\n'
# Trap commands are only executed when triggered
# shellcheck disable=SC2317
trap_err(){
    printf \
        'Error: The program prematurely terminated due to an unhandled error.\n' \
        1>&2
    exit 99
}
if ! trap trap_err ERR; then
    printf \
        'Error: Unable to set the ERR trap.\n' \
        1>&2
    exit 1
fi

if ! shopt -s nullglob; then
    printf \
        'Error: Unable to set the nullglob shell option.\n' \
        1>&2
    exit 2
fi

printf \
    'Info: Checking runtime parameters...\n'
if ! test -e "${GGML_MODEL}"; then
    printf \
        'Error: The specified "%s" GGML model file does not exist.\n' \
        "${GGML_MODEL}" \
        1>&2
    exit 1
fi

if test "${TRANSCRIBE_THREADS}" == auto; then
    printf \
        'Info: Querying the supported CPU thread count...\n'
    if ! cpu_thread_count="$(nproc)"; then
        printf \
            'Error: Unable to query the supported CPU thread count.\n' \
            1>&2
        exit 2
    fi
    printf \
        'Info: CPU thread count determined to be "%s".\n' \
        "${cpu_thread_count}"

    printf \
        'Info: Determining the optimal transcribe thread count...\n'
    transcribe_thread_count="$((cpu_thread_count - TRANSCRIBE_THREADS_NEGATIVE_OFFSET))"
    printf \
        'Info: Optimal transcribe thread count determined to be "%s".\n' \
        "${transcribe_thread_count}"
else
    transcribe_thread_count="${TRANSCRIBE_THREADS}"
fi

inputs=("${@}")
failed_inputs=()

for input in "${inputs[@]}"; do
    if test "${input:0:1}" != /; then
        printf \
            'Info: Determining the absolute path of the "%s" input file...\n' \
            "${input}"
        if ! input_path="$(realpath --strip "${input}")"; then
            printf \
                'Error: Unable to determine the absolute path of the "%s" input file.\n' \
                "${input}" \
                1>&2
            failed_inputs+=("${input}")
            continue
        fi
        printf \
            'Info: The absolute path of the "%s" input file determined to be "%s".\n' \
            "${input}" \
            "${input_path}"
        input="${input_path}"
    fi

    input_dir="${input%/*}"
    input_filename="${input##*/}"
    input_name="${input_filename%.*}"

    subtitle_file="${input_dir}/${input_name}.srt"

    if test -e "${subtitle_file}"; then
        printf \
            'Info: Subtitle file already existed, skipping...\n'
        continue
    fi

    printf \
        'Info: Processing the "%s" input file...\n' \
        "${input}"

    wave_file="${input_dir}/${input_name}.wav"
    if ! test -e "${wave_file}"; then
        printf \
            'Info: Extracting the audio track from the "%s" input file...\n' \
            "${input_filename}"
        ffmpeg_opts=(
            -i "${input}"
            -ar 16000
            -ac 1
            -c:a pcm_s16le
        )
        if ! ffmpeg "${ffmpeg_opts[@]}" "${wave_file}"; then
            printf \
                'Error: Unable to extract the audio track from the "%s" input file.\n' \
                "${input_filename}" \
                1>&2
            failed_inputs+=("${input}")
            continue
        fi
    fi

    printf \
        'Info: Transcribing the subtitles of the "%s" input file from the "%s" audio track file...\n' \
        "${input_filename}" \
        "${wave_file}"
    whispercpp_main_opts=(
        --threads "${transcribe_thread_count}"
        --print-colors
        --print-progress
        --output-srt
        --model "${GGML_MODEL}"
        --language auto
        --file "${wave_file}"
    )
    if ! whisper-cpp.main "${whispercpp_main_opts[@]}"; then
        printf \
            'Error: Unable to transcribe the subtitles of the "%s" input file from the "%s" audio track file.\n' \
            "${input_filename}" \
            "${wave_file}" \
            1>&2
        failed_inputs+=("${input}")
        continue
    fi
done

if test "${#failed_inputs[@]}" -ne 0; then
    printf \
        'Warning: Unable to transcribe the following input files:\n\n' \
        1>&2
    for input in "${failed_inputs[@]}"; do
        printf '* %s\n' "${input}"
    done
    exit 2
else
    printf \
        'Info: Operation completed without errors.\n'
    exit 0
fi
