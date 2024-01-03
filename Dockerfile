FROM demartis/matlab-runtime:R2023a@sha256:9d6b3acd29b974ca0a0c77eca09a34488dcece290c8a4bd04dafaa7c4a5665b2
LABEL maintainer="Bart Schilperoort <b.schilperoort@esciencecenter.nl>"
LABEL org.opencontainers.image.source = "https://github.com/EcoExtreML/STEMMUS_SCOPE"

RUN wget https://github.com/EcoExtreML/STEMMUS_SCOPE/raw/main/run_model_on_snellius/exe/STEMMUS_SCOPE --no-check-certificate

# Make sure the file is executable
RUN chmod +x STEMMUS_SCOPE

CMD ./STEMMUS_SCOPE "" bmi
# Build the image with: `docker build . -t stemmus_scope`
# Then start with the command `docker run -it stemmus_scope`
