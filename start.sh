
export ROOT=$(cd `dirname $0`; pwd)
export CMDLINE="game $*"

if [ $# = 0 ]
then
	echo "Warning:应输入cluster id ......"
fi

killall skynet

nohup $ROOT/skynet $ROOT/geek/boot.lua  &
echo "启动成功!"