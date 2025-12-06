FROM debian:buster

ENV DEBIAN_FRONTEND=noninteractive
ENV PATH="$PATH:/opt/loongarch64-toolchain/bin:/usr/share/dotnet"
ENV https_proxy="$HTTP_PROXY" 
ENV http_proxy="$HTTPS_PROXY"

RUN rm /etc/apt/sources.list \
    && echo 'deb http://mirrors.aliyun.com/debian-archive/debian buster main contrib non-free'  >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.aliyun.com/debian-archive/debian buster-updates main contrib non-free'  >> /etc/apt/sources.list \
    && echo 'deb http://mirrors.aliyun.com/debian-archive/debian-security buster/updates main contrib non-free'  >> /etc/apt/sources.list \
    && dpkg --add-architecture arm64

RUN apt-get update && apt-get install -y \
    wget \
    curl \
    git \
    gnupg \
    software-properties-common \
    ca-certificates \
    build-essential \
    apt-transport-https \
    lsb-release \
    libssl-dev \
    zlib1g-dev \
    zlib1g-dev:arm64 \
    libicu-dev \
    sudo \
    # 安装 ARM64 交叉编译工具链
    gcc-aarch64-linux-gnu \
    g++-aarch64-linux-gnu \
    binutils-aarch64-linux-gnu \
    && rm -rf /var/lib/apt/lists/*

RUN wget -q "https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb" \
    && dpkg -i packages-microsoft-prod.deb \
    && rm packages-microsoft-prod.deb \
    && apt-get update \
    && apt-get install -y powershell \
    && rm -rf /var/lib/apt/lists/*

RUN wget https://apt.llvm.org/llvm.sh \
    && chmod +x llvm.sh \
    && ./llvm.sh 15 \
    && ln -s /usr/bin/clang-15 /usr/bin/clang \
    && ln -s /usr/bin/clang++-15 /usr/bin/clang++ \
    && rm llvm.sh

RUN wget https://github.com/Kitware/CMake/releases/download/v3.28.3/cmake-3.28.3-linux-x86_64.sh -O cmake.sh \
    && chmod +x cmake.sh \
    && ./cmake.sh --skip-license --prefix=/usr/local \
    && rm cmake.sh

RUN mkdir -p /opt/loongarch64-toolchain \
    && wget -q https://github.com/loongson/build-tools/releases/download/2025.08.08/x86_64-cross-tools-loongarch64-binutils_2.45-gcc_15.1.0.tar.xz -O toolchain.tar.xz \
    && tar -xvf toolchain.tar.xz -C /opt/loongarch64-toolchain --strip-components=1 \
    && rm toolchain.tar.xz

RUN wget https://dot.net/v1/dotnet-install.sh -O dotnet-install.sh \
    && chmod +x dotnet-install.sh \
    # 安装 .NET 8 SDK
    && ./dotnet-install.sh --channel 8.0 --install-dir /usr/share/dotnet \
    # 安装 .NET 9 SDK
    && ./dotnet-install.sh --channel 9.0 --install-dir /usr/share/dotnet \
    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
    && rm dotnet-install.sh

ENV PATH="$PATH:/opt/loongarch64-toolchain/bin"

COPY select-objcopy.ps1 /usr/local/bin/select-objcopy
RUN chmod +x /usr/local/bin/select-objcopy
RUN git config --global --add safe.directory '*'

# 验证安装
RUN ls /opt/loongarch64-toolchain/bin && \
    dotnet --info && \
    clang --version && \
    cmake --version && \
    pwsh --version && \
    loongarch64-unknown-linux-gnu-gcc --version

# 设置默认工作目录
WORKDIR /build

CMD ["/bin/bash"]