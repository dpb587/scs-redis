class {
    'scs' :
        redis_options => [
            'save 900 1',
            'save 300 10',
            'save 60 10000',
            'rdbcompression yes',
            'dbfilename dump.rdb',
        ],
        ;
}
