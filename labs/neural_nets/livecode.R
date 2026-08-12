#remotes::install_github('hrbrmstr/iptools')
#remotes::install_github('rundel/livecode')
server <- livecode::serve_file(ip = '127.0.0.1', port = '7777')

livecode::stop_all()

