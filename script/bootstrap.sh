#!/bin/bash
#
#  Copyright (c) 2021, The OpenThread Authors.
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#  3. Neither the name of the copyright holder nor the
#     names of its contributors may be used to endorse or promote products
#     derived from this software without specific prior written permission.
#
#  THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
#  AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
#  LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
#  CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
#  SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
#  INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
#  CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
#  ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#  POSSIBILITY OF SUCH DAMAGE.
#

set -euxo pipefail

install_packages_apt()
{
    echo 'Installing script dependencies...'

    sudo apt-get update && \
        apt-get install --no-install-recommends --allow-unauthenticated -y \
            curl \
            qemu \
            qemu-user-static \
            binfmt-support \
            parted \
            dcfldd \
            xz-utils \
            unzip
}

install_packages_opkg()
{
    echo 'opkg not supported currently' && false
}

install_packages_rpm()
{
    echo 'rpm not supported currently' && false
}

install_packages_source()
{
    echo 'source not supported currently' && false
}

install_packages_pip3()
{
    return
}

install_packages()
{
    PM=source
    if command -v apt-get; then
        PM=apt
    elif command -v rpm; then
        PM=rpm
    elif command -v opkg; then
        PM=opkg
    elif command -v brew; then
        PM=brew
    fi
    install_packages_$PM

    if command -v pip3; then
        install_packages_pip3
    fi
}

main()
{
    install_packages
    echo "Bootstrap completed successfully."
}

main
