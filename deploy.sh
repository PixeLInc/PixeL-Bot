docker run -d --name sgm_stack_bot sgm_stack bin/sgm-bot
docker run -d --name sgm_stack_web -p 7891:7891 sgm_stack bash start_web.sh
