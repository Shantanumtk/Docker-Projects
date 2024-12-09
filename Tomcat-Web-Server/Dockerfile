# Use the official Tomcat image as the base image
FROM tomcat:latest

# Copy your web application (WAR file) to the Tomcat webapps directory
COPY sample.war /usr/local/tomcat/webapps/

# Expose Tomcat port
EXPOSE 8080
CMD ["catalina.sh", "run"]
