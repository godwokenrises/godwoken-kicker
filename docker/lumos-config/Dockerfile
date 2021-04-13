FROM golang:latest
WORKDIR /code
ENV GO111MODULE=on
RUN git clone https://github.com/classicalliu/lumos-config-generator.git
WORKDIR lumos-config-generator
RUN go mod download
RUN go build
RUN echo 'from golang lumos-config' > test.text
RUN ls
#CMD [ "./lumos-config-generator", "lumos-config.json", "http://chain:8114"]
#COPY fix_lumos_bug.sh fix_lumos_bug.sh
#RUN chmod +x fix_lumos_bug.sh
#RUN ./fix_lumos_bug.sh
#CMD [ "./fix_lumos_bug.sh" ]
#RUN exit
