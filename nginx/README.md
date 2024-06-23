## Отличия от nginx образа:

Путь шаблонов: /data/main/nginx-templates
Изменяется с пом переменной: NGINX_ENVSUBST_TEMPLATE_DIR

Суффикс имени шаблона: *.nginx
Изменяется с пом переменной: NGINX_ENVSUBST_TEMPLATE_SUFFIX

## Решаемые задачи
1. Сервинг статических html файлов
1. Подмена переменных на лету
1. Использование переменных среды
2. Компрессия `brotli`

DOCS
https://github.com/yaoweibin/ngx_http_substitutions_filter_module

Внедрение ssi pitfails