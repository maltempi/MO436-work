#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

helpFunction()
{
   echo ""
   echo "Usage: $0 -m [model]"
   printf "Available models:\n- mnist\n- lenet\n- resnet18\n- resnet18_mo436\n- mobilenet\n- squeezenet\n"
   exit 1
}

while getopts "m:" opt
do
   case "$opt" in
      m ) model="$OPTARG" ;;
      ? ) helpFunction ;;
   esac
done

if [ -z "$model" ]
then
  helpFunction
elif [ "$model" != "mnist" ] &&
     [ "$model" != "lenet" ] &&
     [ "$model" != "resnet18" ] &&
     [ "$model" != "resnet18_mo436" ] &&
     [ "$model" != "mobilenet" ] &&
     [ "$model" != "squeezenet" ]
then
  helpFunction
fi

echo "Executing model..."
cd ../models/$model/bin

if [ "$model" == "mnist" ] ||
   [ "$model" == "lenet" ]
then
  ground_truth=$DIR/ground_truth_mnist.txt
  ./main.x ../../../datasets/mnist/mnist*.png > $model.res
  cd $DIR; clang++ -o measure_mnist measure_mnist.cpp
  ./measure_mnist ../models/$model/bin/$model.res $ground_truth
else
  ground_truth=$DIR/ground_truth_imagenet.txt
  ./main.x ../../../datasets/imagenet/val*.png > $model.res
  cd $DIR; clang++ -o measure_acc measure_acc.cpp
  ./measure_acc ../models/$model/bin/$model.res $ground_truth
fi

