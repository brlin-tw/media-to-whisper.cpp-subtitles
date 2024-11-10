# media-to-whisper.cpp-subtitles

Converting user-specified media files to subtitles using the Whisper.cpp utility.

<https://gitlab.com/brlin/media-to-whisper.cpp-subtitles>  
[![The GitLab CI pipeline status badge of the project's `main` branch](https://gitlab.com/brlin/media-to-whisper.cpp-subtitles/badges/main/pipeline.svg?ignore_skipped=true "Click here to check out the comprehensive status of the GitLab CI pipelines")](https://gitlab.com/brlin/media-to-whisper.cpp-subtitles/-/pipelines) [![GitHub Actions workflow status badge](https://github.com/brlin-tw/media-to-whisper.cpp-subtitles/actions/workflows/check-potential-problems.yml/badge.svg "GitHub Actions workflow status")](https://github.com/brlin-tw/media-to-whisper.cpp-subtitles/actions/workflows/check-potential-problems.yml) [![pre-commit enabled badge](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white "This project uses pre-commit to check potential problems")](https://pre-commit.com/) [![REUSE Specification compliance badge](https://api.reuse.software/badge/gitlab.com/brlin/media-to-whisper.cpp-subtitles "This project complies to the REUSE specification to decrease software licensing costs")](https://api.reuse.software/info/gitlab.com/brlin/media-to-whisper.cpp-subtitles)

## Prerequisites

You need to have the following software installed and it's command available in the command search PATHs:

* GNU core utilities  
  For determining the absolute path of the utility and the available threads to do the subtitle inference.
* whisper.cpp  
  For inferencing the subtitles from the media's audio tracks.

  By default it uses [the unofficial snap distribution](https://snapcraft.io/whisper-cpp) of Whisper.cpp.
* FFmpeg  
  For converting the input media into formats that can be consumed by whisper.cpp.

## Usage

Refer to the following instructions to use this application:

1. Download the application's release package from [the Releases page](https://gitlab.com/brlin/media-to-whisper.cpp-subtitles/-/releases).
1. Extract the downloaded application release package using your preferred archive manipulation utility.
1. Launch your preferred text terminal emulator application.
1. Refer to [the Environment variables that can change the utility's behaviors section](#environment-variables-that-can-change-the-utilitys-behaviors) for environment variables that can change the utility's behaviors according to your preference and run the utility by running the following command:

    ```bash
    _ENV_VAR_NAME1_=_env_var_value1_ _ENV_VAR_NAME2_=_env_var_value2_... \
        /path/to/media-to-whisper.cpp-subtitles/transcribe-media-to-subtitles.sh \
        _input_media_1_ _input_media_2_...
    ```

   The generated subtitles files will be saved in the same directory with the input files.

## Environment variables that can change the utility's behaviors

The following environment variables can change the utility's behaviors according to your preference, use these environment variables to optimize your workload:

### GGML_MODEL

The whisper.cpp model file to infer the subtitles.

**Supported values:**

* (Absolute path of the model file you want to use)
* (Relative path of the model file you want to use)

**Default value:** `ggml-medium.bin`

### TRANSCRIBE_THREADS

The thread count for doing the subtitle transcribe task.

**Supported values:**

* `auto`: Automatically determine the optimal transcribe thread count while taken [the `TRANSCRIBE_THREADS_NEGATIVE_OFFSET` environment variable](#transcribe_threads_negative_offset) into consideration
* (A natural number of user-specified thread count)

**Default value:** `auto`

### TRANSCRIBE_THREADS_NEGATIVE_OFFSET

When [the `TRANSCRIBE_THREADS` environment variable](#transcribe_threads) is set to `auto`, this environment variable determines the negative offset that will be applied to the transcribe thread count to allow user to adapt it to their system's optimal settings.

**Supported values:**

(A non-negative number that will be deducted from the detected thread count available to the process)

**Default value:**

`1` (Deduct one from the detected available thread count, on a 8 total CPU thread system the optimal transcribe thread count will be determined to be `7`)

### WHISPERCPP_MAIN

Specify the base command of the Whisper.cpp main program.  This environment variable allows users to use a different Whisper.cpp distribution other than the snap.

**Supported values:**

* The path of a valid Whisper.cpp main program.
* The base command of a valid Whisper.cpp main program, if it is in the command search PATHs.

**Default value:** `whisper-cpp-main`

Use [the unofficial snap distribution](https://snapcraft.io/whisper-cpp)'s main app command.

## Licensing

Unless otherwise noted(individual file's header/[REUSE.toml](REUSE.toml)), this product is licensed under [the 3.0 version of the GNU Affero General Public License](https://www.gnu.org/licenses/agpl-3.0.en.html), or any of its more recent versions of your preference.

This work complies to [the REUSE Specification](https://reuse.software/spec/), refer the [REUSE - Make licensing easy for everyone](https://reuse.software/) website for info regarding the licensing of this product.
