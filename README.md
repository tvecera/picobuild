# PicoSDK & PicoLibSDK Docker Image

A Docker image that provides a complete development environment for building Raspberry Pi Pico projects using both
PicoSDK and PicoLibSDK. This container includes all necessary toolchains, libraries, and utilities required for Pico
development without having to install anything locally (except Docker or Podman).

## Features

- Pre-installed Raspberry Pi Pico SDK (tag: 2.1.1)
- Pre-installed PicoLibSDK
- ARM GNU toolchain (13.2.Rel1)
- RISC-V toolchain for the second Pico RP2350 core (14)
- Build tools (cmake, make, ninja)
- Development utilities (git, vim, mc)
- Dev Container configuration for VS Code or CLion IDE
- Example projects for both PicoSDK and PicoLibSDK
- Supports both x86_64 and ARM64 architectures

## Prerequisites

- Docker or Podman installed on your system
- (Optional) Visual Studio Code with Dev Containers extension for using the devcontainer

## Getting Started

### Using the Docker Image

Pull the image from Docker Hub:

```bash
docker pull ghcr.io/tvecera/picobuild:latest
# OR using Podman
podman pull ghcr.io/tvecera/picobuild:latest
```

Or build it locally:

```bash
docker build -t picobuild:latest .
# OR using Podman
podman build -t picobuild:latest .
```

### Build Arguments

The Dockerfile supports several build arguments that allow you to customize the image:

| Argument              | Default                                    | Description                                             |
|-----------------------|--------------------------------------------|---------------------------------------------------------|
| `PICO_SDK_TAG`        | `2.1.1`                                    | Version tag of the Raspberry Pi Pico SDK                |
| `PICO_LIB_SDK_COMMIT` | `fda46ebbef24c0a0655c45134ea92faf66c6548d` | Commit hash for PicoLibSDK                              |
| `USERNAME`            | `vscode`                                   | Username for the non-root user created in the container |
| `USER_UID`            | `1001`                                     | User ID for the non-root user                           |
| `USER_GID`            | `1001`                                     | Group ID for the non-root user                          |

Example of building with custom arguments:

```bash
# Using Docker
docker build -t picobuild:latest \
  --build-arg PICO_SDK_TAG=2.1.1 \
  --build-arg USERNAME=developer \
  --build-arg USER_UID=1002 \
  --build-arg USER_GID=1002 \
  .
  
# Using Podman
podman build -t picobuild:latest \
  --build-arg PICO_SDK_TAG=2.1.1 \
  --build-arg USERNAME=developer \
  --build-arg USER_UID=1002 \
  --build-arg USER_GID=1002 \
  .  
```

### Toolchain Caching

The Dockerfile is optimized to support caching of the large toolchain downloads to speed up subsequent builds. To use
this feature:

1. Create a `toolchain-archives` directory in the same location as your Dockerfile
2. Download the toolchain archives manually or let the first build download them
3. After the first successful build, the toolchain files will be available in the `toolchain-archives` directory
4. Subsequent builds will use these cached files instead of downloading them again

Supported toolchain files:

- ARM GCC Toolchain: `arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz` (for x86_64) or
  `arm-gnu-toolchain-13.2.rel1-aarch64-arm-none-eabi.tar.xz` (for ARM64)
- RISC-V Toolchain: `riscv-toolchain-14-x86_64-lin.tar.gz` (for x86_64) or `riscv-toolchain-14-aarch64-lin.tar.gz` (for
  ARM64)

This significantly speeds up build times and reduces bandwidth usage when working with multiple builds or CI/CD
pipelines.

### Build Examples

#### PicoSDK Example

Using Docker:

```bash
docker run --rm --privileged \
  -v $(pwd)/example/picosdk:/workspaces/project -w /workspaces/project \
  ghcr.io/tvecera/picobuild:latest \
  sh -c "mkdir -p build && cd build && cmake .. && make clean && make -j4"
```

Using Podman:

```bash
podman run --rm --privileged \
  -v $(pwd)/example/picosdk:/workspaces/project -w /workspaces/project \
  ghcr.io/tvecera/picobuild:latest \
  sh -c "mkdir -p build && cd build && cmake .. && make clean && make -j4"
```

#### PicoLibSDK Example

Using Docker:

```bash
docker run --rm --privileged \
  -v $(pwd)/example/picolibsdk:/workspaces/project -w /workspaces/project \
  ghcr.io/tvecera/picobuild:latest \
  sh -c "/workspaces/project/c.sh pico"
```

Using Podman:

```bash
podman run --rm --privileged \
  -v $(pwd)/example/picolibsdk:/workspaces/project -w /workspaces/project \
  ghcr.io/tvecera/picobuild:latest \
  sh -c "/workspaces/project/c.sh pico"
```

### Using with VS Code Dev Containers

1. Install the "Remote - Containers" extension in VS Code
2. Clone this repository
3. Open the repository in VS Code
4. When prompted, click "Reopen in Container" or use the command palette and select "Remote-Containers: Reopen in
   Container"
5. VS Code will build the container and set up the development environment

## Project Structure

```
.
├── .devcontainer/         # Dev Container configuration
├── example/
│   ├── picosdk/           # Example PicoSDK project
│   └── picolibsdk/        # Example PicoLibSDK project
├── toolchain-archives/    # Optional folder for caching toolchain downloads
├── Dockerfile             # Docker image definition
└── README.md              # This file
```

## Environment Details

The Docker image provides the following components:

- **PicoSDK Path**: `/opt/pico-sdk` (version 2.1.1)
- **PicoLibSDK Path**: `/opt/PicoLibSDK` (version 2.07)
- **ARM Toolchain**: `/opt/arm-gcc` 
  - For x86_64: `arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi`
  - For ARM64: `arm-gnu-toolchain-13.2.rel1-aarch64-arm-none-eabi`
- **RISC-V Toolchain**: `/opt/riscv-gcc`
  - For x86_64: `riscv-toolchain-14-x86_64-lin`
  - For ARM64: `riscv-toolchain-14-aarch64-lin`

The environment is pre-configured with all necessary environment variables, including `PICO_SDK_PATH`.

## Development Tools

The following tools are included in the Docker image:

- CMake
- Make
- Ninja
- Git
- Vim
- Midnight Commander (mc)
- picotool
- elf2uf2
- LoaderCrc

## Customization

You can modify the Dockerfile to customize the environment:

- Change SDK versions by modifying the ARG variables at the top
- Add additional development tools by extending the apt-get install section
- Install additional Python packages if needed

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is open source and available under the [MIT License](LICENSE).

## Acknowledgments

- [Raspberry Pi Pico SDK](https://github.com/raspberrypi/pico-sdk)
- [PicoLibSDK](https://github.com/Panda381/PicoLibSDK)