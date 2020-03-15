project(
    'elementary-account',
    'vala', 'c',
    version: '1.0.0',
    meson_version: '>= 0.46.0'
)

add_project_arguments(
    ['-DGETTEXT_PACKAGE="' + meson.project_name() + '"'],
    language:'c'
)

webkit_dep = dependency('webkit2gtk-4.0')
soup_dep = dependency('libsoup-2.4')
json_dep = dependency('json-glib-1.0')
secret_dep = dependency('libsecret-1')
granite_dep = dependency('granite')

subdir('src')
subdir('example')

