FROM alpine:3.13

RUN apk add ruby=2.7.2-r3

ARG USER=devuser
ENV HOME /home/$USER
# -g for GECOS (user info) -D for no password, -u for UID
# create user and group with same name
RUN adduser $USER $USER -g '' -D -u 1000

RUN mkdir /site && chown $USER:$USER -R /site
USER $USER

RUN gem install --user-install asciidoctor-multipage
# Update PATH so that gem executables we installed can be run.
ENV PATH /home/devuser/.gem/ruby/2.7.0/bin:$PATH

WORKDIR $HOME/prose
COPY static static
COPY prose.sh .

ENTRYPOINT [ "time", "/home/devuser/prose/prose.sh" ]
