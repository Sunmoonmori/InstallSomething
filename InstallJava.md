# jdk1.8.0_301-linux-x64
```
tar zxvf jdk-8u301-linux-x64.tar.gz
sudo mkdir /usr/java
sudo mv jdk1.8.0_301 /usr/java
```
# profile
```
export JAVA_HOME=/usr/java/jdk1.8.0_301
export JRE_HOME=/usr/java/jdk1.8.0_301/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib:$CLASSPATH
export PATH=$JAVA_HOME/bin:$JRE_HOME/bin:$PATH
```