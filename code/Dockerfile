FROM python:3.8.2-buster

RUN groupadd -g 999 -r web && useradd -r --uid 999 -g web web
ENV FLASK_APP=validator
ENV FLASK_ENV=production
ENV SERVER_NAME=0.0.0.0:3000
EXPOSE 3000

WORKDIR /workdir

COPY requirements.txt /workdir

RUN pip install -r requirements.txt

COPY . /workdir

RUN pip install -e .

USER web

CMD ./start.sh
