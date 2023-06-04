FROM python:3.10
RUN apt update && apt install -y \
    curl \
    gpg
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | gpg --dearmor -o /usr/share/keyrings/githubcli-archive-keyring.gpg;
RUN echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null;
RUN apt update && apt install -y gh;
RUN pip install hatch id;
WORKDIR /app
COPY entrypoint.sh /app/entrypoint.sh
COPY oidc-exchange.py /app/oidc-exchange.py
ENTRYPOINT ["/app/entrypoint.sh"]
