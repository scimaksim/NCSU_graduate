To create a container image, run:
`podman build -t shinyapp .`

To launch the container, run:
`podman run -d -p 3838:3838 localhost/shinyapp`
