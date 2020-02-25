##### Linux4SAM: sync repos, chackout branches and build

Install build tools:

sudo add-apt-repository ppa:team-gcc-arm-embedded/ppa

sudo apt-get update

sudo apt-get install gcc-arm-embedded



Clone repo:

git clone https://github.com/petarupinov/manifest-sama5d2-xult.git



Run script:

./sama5d2-xplained-ultra-linux-release.sh
