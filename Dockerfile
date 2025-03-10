FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/sdk:9.0-bookworm-slim AS build-env

ARG TARGETARCH

WORKDIR /app

COPY . .

# Private Nuget feed
# NuGet.config file must be in the root of the project
# RUN --mount=type=secret,id=github_token \
#    dotnet nuget update source github --username <org> --password $(cat /run/secrets/github_token) --store-password-in-clear-text  --configfile NuGet.Config


# restore dependencies
RUN dotnet restore ./src/DemoApi/ -a $TARGETARCH

# build
RUN dotnet publish ./src/DemoApi/ -c Release --no-restore -o out -a $TARGETARCH --self-contained false -p:PublishSingleFile=true

# Create runtime image
FROM --platform=$BUILDPLATFORM mcr.microsoft.com/dotnet/aspnet:9.0-bookworm-slim

WORKDIR /app

ENV TZ Europe/Prague

# required to enable read only root filesystem
ENV COMPlus_EnableDiagnostics=0

USER 1001

COPY --from=build-env /app/out .

ENTRYPOINT ["./DemoApi"]
