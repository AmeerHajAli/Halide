autoschedulers="beam mcts"
#autoschedulers="master greedy beam mcts"

if [ $# -lt 1 ]; then
    weights=""
elif  [ "$1" == "--improved" ]; then
    weights="--improved"
elif  [ "$1" == "--value_func" ]; then
    weights="--value_func"
else 
    echo "Invalid command line option!"
fi

APPS="bilateral_grid local_laplacian nl_means lens_blur camera_pipe stencil_chain harris hist max_filter unsharp interpolate conv_layer mat_mul iir_blur bgu" # resnet_50_blockwise is handled by a special case at the end
#APPS="resnet"
echo > progress

for autoscheduler in $autoschedulers; do
    for app in ${APPS}; do
    	export RL_FIRST="true"
    	SEED=0	
	SECONDS=0
        while [ $SECONDS -lt 900 ]; do
	    SEED=$((SEED+1))
    	    export HL_SEED="$SEED"

            echo "$autoscheduler $app" >> progress
            ./generate_apps_results.sh $autoscheduler $weights $app
	    if [ $? -ne 0 ]; then
	    	echo "Failed to get results for $autoscheduler"
	        exit 1
	    fi
    	    export RL_FIRST="false"

    	done
    done
done

cd plots
./extract > results.csv
./extract_run
