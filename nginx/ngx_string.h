typedef struct {
    size_t len;
    u_char *data;
} ngx_str_t;


typedef struct {
ngx_str_t hello_string;
ngx_int_t hello_counter;
} ngx_http_hello_conf_t;




