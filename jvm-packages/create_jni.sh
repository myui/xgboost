#!/usr/bin/env bash
echo "build java wrapper"

# cd to script's directory
pushd `dirname $0` > /dev/null

# environment settings
java=`echo $JAVA_HOME`"/bin/java"
osinfo_class="ml.dmlc.xgboost4j.java.OSInfo"
os_name=`${java} -cp bin ${osinfo_class} --os`
arch_name=`${java} -cp bin ${osinfo_class} --arch`

# turn off OpenMp by default for portable compilation
use_omp=0
if [ "`echo $XGBOOST_USE_OMP`" == "1" ]; then
  use_omp=1
fi

cd ..
make CXX=g++ USE_OPENMP=${use_omp} jvm
cd jvm-packages

echo "move native lib"
libPath="xgboost4j/src/main/resources/lib/${os_name}/${arch_name}/"
rm -rf "$libPath"
mkdir -p "$libPath"

strip lib/libxgboost4j.so

if [ "${os_name}" == "Mac" ]; then
  mv lib/libxgboost4j.so lib/libxgboost4j.dylib
  cp lib/libxgboost4j.dylib ${libPath}
else
  cp lib/libxgboost4j.so ${libPath}
fi

# copy python to native resources
cp ../dmlc-core/tracker/dmlc_tracker/tracker.py xgboost4j/src/main/resources/tracker.py
# copy test data files
mkdir -p xgboost4j-spark/src/test/resources/
cp ../demo/data/agaricus.* xgboost4j-spark/src/test/resources/
popd > /dev/null
echo "complete"
