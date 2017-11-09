echo Type your repo:
read repo
echo Type folder name:
read folder
echo Type build tool:
read build_tool
echo Type tomcat user:
read tomcat_user
echo Type tomcat password:
read tomcat_password
echo Type tomcat host:
read tomcat_host
echo Type tomcat port:
read tomcat_port
git clone $repo $folder
cd $folder
if [[ "$build_tool" = "maven" ]]; then
	mvn package
	path=web/target/*.war
fi
if [[ "$build_tool" = "gradle" ]]; then
	gradle build
	path=web/build/libs/*.war
fi
curl --upload-file $path "http://$tomcat_user:$tomcat_password@$tomcat_host:$tomcat_port/manager/text/deploy?path=/$folder&update=true"
sleep 60
while [ 1 ];
do
	git fetch origin
	diff=$(git diff origin/master)
	if  [[ "$diff" != "" ]]; then
		git pull
		if [[ "$build_tool" = "maven" ]]; then
			mvn clean
			mvn package
			path=target/*.war
		fi
		if [[ "$build_tool" = "gradle" ]]; then
			gradle clean
			gradle build
			path=build/libs/*.war
		fi
		curl --upload-file $path "http://$tomcat_user:$tomcat_password@$tomcat_host:$tomcat_port/manager/text/deploy?path=/$folder&update=true"
	fi
	sleep 60
done
