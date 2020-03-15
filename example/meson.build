example_files = files(
    'AddCardFlow.vala',
    'CardRow.vala',
    'LoginFlow.vala',
    'MainWindow.vala',
    'PurchaseFlow.vala',
)

granite_dep = dependency('granite')

executable(
    'example',
    example_files,
    dependencies: [elementary_accounts_library_dep, granite_dep]
)
