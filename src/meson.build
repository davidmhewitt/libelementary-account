library_files = files (
    'AccountManager.vala',
    'Card.vala',
    'Constants.vala',
    'NativeWebView.vala',
    'Utils.vala'
)

elementary_accounts_library_build_deps = [
    webkit_dep,
    json_dep,
    secret_dep,
]

elementary_accounts_library = shared_library(
    meson.project_name (),
    library_files,
    vala_gir: 'ElementaryAccount-1.0.gir',
    dependencies: elementary_accounts_library_build_deps,
    install: true,
    install_dir: [true, true, true, true]
)

elementary_accounts_library_dep = declare_dependency(
    link_with: elementary_accounts_library,
    include_directories: include_directories('.'),
    dependencies: elementary_accounts_library_build_deps
)
