VER=10
COMMIT=280e795c1

brew install open-mpi
brew install gnu-sed
brew install boost
brew install cgal
brew install metis
brew install scotch
brew tap mrklein/foam
brew install mrklein/foam/parmgridgen
cd
hdiutil create -size 8.3g -type SPARSEBUNDLE -fs HFSX -volname OpenFOAM -fsargs -s OpenFOAM.sparsebundle
hdiutil attach -mountpoint $HOME/OpenFOAM OpenFOAM.sparsebundle
cd OpenFOAM
git clone https://github.com/OpenFOAM/OpenFOAM-$VER.git
cd OpenFOAM-$VER
git checkout -b local-install $COMMIT

curl -L https://raw.githubusercontent.com/mrklein/openfoam-os-x/master/OpenFOAM-$VER-$COMMIT.patch > OpenFOAM-$VER-$COMMIT.patch
gsed -i 's/x86_64/arm64/g' OpenFOAM-$VER-$COMMIT.patch
git apply OpenFOAM-$VER-$COMMIT.patch
git add .
git commit -m 'Applied OpenFOAM patch with arm64'

curl -L https://raw.githubusercontent.com/AleksZhuravlyov/openFoamThings/master/sigFpe.C.patch > sigFpe.C.patch
git apply sigFpe.C.patch
git add .
git commit -m 'Applied sigFpe.C patch'

curl -L https://raw.githubusercontent.com/AleksZhuravlyov/openFoamThings/master/foam_final_setup.patch > foam_final_setup.patch
git apply foam_final_setup.patch
git add .
git commit -m 'Applied foam_final_setup patch'

mkdir -p $HOME/.OpenFOAM
echo 'WM_COMPILER=Clang' > $HOME/.OpenFOAM/prefs.sh
echo 'WM_COMPILE_OPTION=Opt' >> $HOME/.OpenFOAM/prefs.sh
echo 'WM_MPLIB=SYSTEMOPENMPI' >> $HOME/.OpenFOAM/prefs.sh
echo 'export WM_NCOMPPROCS=$(sysctl -n hw.ncpu)' >> $HOME/.OpenFOAM/prefs.sh
echo 'WM_LABEL_SIZE=32' >> $HOME/.OpenFOAM/prefs.sh
echo $VER > $HOME/.OpenFOAM/OpenFOAM-release
source etc/bashrc
[ "$(ulimit -n)" -lt "4096" ] && ulimit -n 4096
./Allwmake | tee log.Allwmake 2>&1

# add to .zshrc file:
# if [ -f "$HOME/.OpenFOAM/OpenFOAM-release" ]; then
#     FOAM_DISK_IMAGE=${FOAM_DISK_IMAGE:-"$HOME/OpenFOAM.sparsebundle"}
#     FOAM_MOUNT_POINT=${FOAM_MOUNT_POINT:-"$HOME/OpenFOAM"}
#     FOAM_VERSION=$(cat $HOME/.OpenFOAM/OpenFOAM-release)
#     if [ ! -f "$HOME/OpenFOAM/OpenFOAM-$FOAM_VERSION/etc/bashrc" ]; then
#         hdiutil attach -quiet -mountpoint "$FOAM_MOUNT_POINT" "$FOAM_DISK_IMAGE" &&
#                 . "$HOME/OpenFOAM/OpenFOAM-$FOAM_VERSION/etc/bashrc"
#     else
#         source "$HOME/OpenFOAM/OpenFOAM-$FOAM_VERSION/etc/bashrc"
#     fi
# fi
# 
# FOAM_VERSION=$(cat $HOME/.OpenFOAM/OpenFOAM-release)
# source "$HOME/OpenFOAM/OpenFOAM-$FOAM_VERSION/etc/bashrc"
# 
# echo 'FOAM VERSION' $FOAM_VERSION