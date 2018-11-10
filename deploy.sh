docker run --name bot sgm_stack /app/bin/bot
docker run --name web -p 8080:8080 sgm_stack /app/start_web.sh
