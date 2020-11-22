#!/bin/zsh
###
 # @Description: hexo博客部署脚本
 # @version: 
 # @Auther: protosskai
 # @Date: 2020-11-12 18:50:19
 # @LastEditTime: 2020-11-22 12:27:29
### 

hexo clean > /dev/null
if [ $? -ne 0 ];then
	echo "清理项目失败！"
	exit
fi
hexo g > /dev/null
if [ $? -ne 0 ];then
	echo "部署项目失败！"
	exit
fi
cd ./public && mkdir source && cd ../
cp ./source/_posts/*.md ./public/source
cp ./deploy.sh ./public
hexo d
