FROM node:18.12.0-alpine

ARG GIT_ACCESS_KEY

WORKDIR /usr/src/app

COPY . .

RUN apk update
RUN apk add openssh git

RUN mkdir ~/.ssh && \
  ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

RUN echo $GIT_ACCESS_KEY | base64 -d > ~/.ssh/id_rsa && \
  chmod 400 ~/.ssh/id_rsa

RUN eval $(ssh-agent -s) && \
  ssh-add ~/.ssh/id_rsa

RUN npm install -g pnpm

RUN pnpm install

RUN pnpm build

ADD https://github.com/ufoscout/docker-compose-wait/releases/download/2.9.0/wait /wait
RUN chmod +x /wait

EXPOSE 3000

CMD ["/bin/sh","-c","source /etc/profile && /wait && pnpm start"]