FROM ubuntu:24.04

ARG PICO_SDK_TAG=2.1.1
ARG PICO_LIB_SDK_COMMIT=cd229d2e2cd2985187cae6a4de59815b23083dc8
ARG USERNAME=vscode
ARG USER_UID=1001
ARG USER_GID=1001

# Set non-interactive installation
ENV DEBIAN_FRONTEND=noninteractive

# Copy potential cached toolchain files
RUN mkdir -p /tmp/toolchain-archives
COPY ./toolchain-archives/* /tmp/toolchain-archives/

# Update and install minimal required packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    ca-certificates \
    sudo \
    build-essential \
    cmake \
    python3 \
    python3-pip \
    curl \
    automake \
    autoconf \
    texinfo \
    libtool \
    libftdi-dev \
    libusb-1.0-0-dev \
    pkg-config \
    libhidapi-dev \
    minicom \
    wget \
    ninja-build \
    vim \
    mc \
    git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create non-root user
RUN groupadd --gid ${USER_GID} ${USERNAME} && \
    useradd --uid ${USER_UID} --gid ${USER_GID} -m ${USERNAME} && \
    echo ${USERNAME} ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/${USERNAME} && \
    chmod 0440 /etc/sudoers.d/${USERNAME}

# Install ARM toolchain
RUN mkdir -p /tmp/arm-gcc && \
    cd /tmp/arm-gcc && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        ARM_PACKAGE_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz" && \
        ARM_PACKAGE_FILE="arm-gnu-toolchain-13.2.rel1-x86_64-arm-none-eabi.tar.xz" && \
        ARM_PACKAGE_DIR="arm-gnu-toolchain-13.2.Rel1-x86_64-arm-none-eabi"; \
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
        ARM_PACKAGE_URL="https://developer.arm.com/-/media/Files/downloads/gnu/13.2.rel1/binrel/arm-gnu-toolchain-13.2.rel1-aarch64-arm-none-eabi.tar.xz" && \
        ARM_PACKAGE_FILE="arm-gnu-toolchain-13.2.rel1-aarch64-arm-none-eabi.tar.xz" && \
        ARM_PACKAGE_DIR="arm-gnu-toolchain-13.2.Rel1-aarch64-arm-none-eabi"; \
    else \
        echo "Unsupported architecture for ARM toolchain: $ARCH" && \
        exit 1; \
    fi && \
    if [ -f "/tmp/toolchain-archives/$ARM_PACKAGE_FILE" ]; then \
        echo "Using cached ARM toolchain archive" && \
        cp "/tmp/toolchain-archives/$ARM_PACKAGE_FILE" .; \
    else \
        echo "Downloading ARM toolchain" && \
        wget --progress=bar:force "$ARM_PACKAGE_URL";

    fi && \
    tar -xf "$ARM_PACKAGE_FILE" && \
    mkdir -p /opt/arm-gcc && \
    cp -a "$ARM_PACKAGE_DIR/"* /opt/arm-gcc/ && \
    ln -sf /opt/arm-gcc/bin/* /usr/local/bin/ && \
    cd /tmp && \
    rm -rf /tmp/arm-gcc

# Install RISC-V toolchain
RUN mkdir -p /tmp/riscv-gcc && \
    cd /tmp/riscv-gcc && \
    ARCH=$(uname -m) && \
    if [ "$ARCH" = "x86_64" ]; then \
        RISCV_PACKAGE_URL="https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.0.0-5/riscv-toolchain-14-x86_64-lin.tar.gz" && \
        RISCV_PACKAGE_FILE="riscv-toolchain-14-x86_64-lin.tar.gz"; \
    elif [ "$ARCH" = "aarch64" ] || [ "$ARCH" = "arm64" ]; then \
        RISCV_PACKAGE_URL="https://github.com/raspberrypi/pico-sdk-tools/releases/download/v2.0.0-5/riscv-toolchain-14-aarch64-lin.tar.gz" && \
        RISCV_PACKAGE_FILE="riscv-toolchain-14-aarch64-lin.tar.gz"; \
    else \
        echo "Unsupported architecture: $ARCH" && \
        exit 1; \
    fi && \
    if [ -f "/tmp/toolchain-archives/$RISCV_PACKAGE_FILE" ]; then \
        echo "Using cached RISC-V toolchain archive" && \
        cp "/tmp/toolchain-archives/$RISCV_PACKAGE_FILE" .; \
    else \
        echo "Downloading RISC-V toolchain" && \
        wget --progress=bar:force "$RISCV_PACKAGE_URL"; \
    fi && \
    tar -xf "$RISCV_PACKAGE_FILE" && \
    rm "$RISCV_PACKAGE_FILE" && \
    mkdir -p /opt/riscv-gcc && \
    cp -a /tmp/riscv-gcc/* /opt/riscv-gcc/ && \
    ln -sf /opt/riscv-gcc/bin/* /usr/local/bin/ && \
    cd /tmp && \
    rm -rf /tmp/riscv-gcc && \
    rm /opt/riscv-gcc/bin/riscv32-unknown-elf-lto-dump && \
    rm /opt/riscv-gcc/bin/riscv32-unknown-elf-gdb

# Clean up toolchain archives directory
RUN rm -rf /tmp/toolchain-archives

# Install Pico SDK
RUN mkdir -p /opt && \
    cd /opt && \
    git clone https://github.com/raspberrypi/pico-sdk.git --branch "${PICO_SDK_TAG}" --depth 1 && \
    cd pico-sdk && \
    git submodule update --init && \
    chmod -R a+rwx /opt/pico-sdk && \
    rm -rf /opt/pico-sdk/.git

# Install picotool
RUN cd /opt && \
    git clone https://github.com/raspberrypi/picotool.git --depth 1 && \
    cd picotool && \
    mkdir -p build && \
    cd build && \
    PICO_SDK_PATH=/opt/pico-sdk cmake .. && \
    make -j$(nproc) && \
    make install && \
    rm -rf /opt/picotool

# Install PicoLibSDK
RUN cd /opt && \
    git clone https://github.com/Panda381/PicoLibSDK.git --depth 1 && \
    cd PicoLibSDK && \
    git fetch --depth=1 origin "${PICO_LIB_SDK_COMMIT}" && \
    git checkout "${PICO_LIB_SDK_COMMIT}" && \
    cd .. && \
    chmod -R a+rwx /opt/PicoLibSDK/ && \
    cd PicoLibSDK/_tools/elf2uf2 && \
    g++ -o elf2uf2 main.cpp && \
    cp elf2uf2 /usr/local/bin/ && \
    cd ../PicoPadLoaderCrc/ && \
    g++ -o LoaderCrc LoaderCrc.cpp && \
    cp LoaderCrc /usr/local/bin/ && \
    rm -rf /opt/PicoLibSDK/\!* && \
    rm -rf /opt/PicoLibSDK/PicoPad && \
    rm -rf /opt/PicoLibSDK/DemoVGA && \
    rm -rf /opt/PicoLibSDK/Picoino && \
    rm -rf /opt/PicoLibSDK/Pico && \
    rm -rf /opt/PicoLibSDK/.git

# Clean up to reduce image size
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Set environment variable
ENV PICO_SDK_PATH=/opt/pico-sdk

# Switch to non-root user
USER $USERNAME

WORKDIR /workspaces

# Reset to interactive mode
ENV DEBIAN_FRONTEND=

# Display setup complete message
RUN echo "-------------------------------------------------------" && \
    echo " Setup complete!" && \
    echo " PICO_SDK_PATH has been set to /opt/pico-sdk (tag: ${PICO_SDK_TAG})" && \
    echo " ARM toolchain installed at /opt/arm-gcc" && \
    echo " Risc-V toolchain installed at /opt/riscv-gcc" && \
    echo "-------------------------------------------------------"