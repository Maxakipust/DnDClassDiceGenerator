# set -o xtrace
echo $1
VERSION=${1:-"release"}

echo "====Checking dependencies===="

for font in "MyDNDFont" "Luminari"; do
    if fc-list | grep -q $font; then
        echo "Found font: ${font}"
    else
        echo "Missing font: ${font}"
        echo "install missing fonts by running: \"sudo cp fonts/* /usr/share/fonts && sudo fc-cache -f -v\""
        exit 1
    fi
done

if openscad --version > /dev/null; then
    echo "Found openscad"
else
    echo "Missing openscad"
    echo "Install from https://openscad.org/"
    exit 1
fi

echo "====All dependencies found===="

mkdir -p build/${VERSION}

ALL_CLASSES=("Barb" "Druid" "Pal" "Bard" "Fighter" "Warlock" "Cleric" "Monk" "Rogue" "Wiz" "DND" "Range" "Sorc")

for class in ${ALL_CLASSES[@]}; do
    echo "Starting ${class}"
    openscad \
    --export-format binstl -o "build/${VERSION}/${class}_${VERSION}.stl" \
    -p PolyDiceGenerator.json -P ${class} \
    PolyDiceGenerator.scad > "build/${VERSION}/${class}_${VERSION}.log" 2>&1 &
done
wait
echo "Finished"


echo "Cleaning up logs"
logfile=build/${VERSION}/build.log
touch $logfile
for class in ${ALL_CLASSES[@]}; do
    echo "====${class}====" >> $logfile
    cat build/${VERSION}/${class}_${VERSION}.log >> $logfile
    echo -e "\n\n" >> $logfile
    rm build/${VERSION}/${class}_${VERSION}.log
done
echo "Finished"