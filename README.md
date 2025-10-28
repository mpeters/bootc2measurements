# bootc2measurements

A utility script to convert a bootc container image into a list of reference measurements for attesting file integrity.

## Installation

This is a simple bash script that should just be copiable. It does require that the following are installed:

    * wget
    * podman

## Usage

```
    Usage: ./bootc2measurements.sh -i/--image BOOTC_IMAGE [-h/--help]

    optional arguments:
        -o/--output_file FILNAME     (optional name of output file. Defaults to measurements.txt)
        -h/--help                    (show this message and exit)
```

```bash
./bootc2measurements.sh --image quay.io/fedora/fedora-bootc:43

./bootc2measurements.sh --image quay.io/fedora/fedora-bootc:43 --output hashes.txt
```

## Contributing

Pull requests are welcome. For major changes, please open an issue first
to discuss what you would like to change.

Please make sure to update tests as appropriate.

## License

[Apache 2](https://choosealicense.com/licenses/apache-2.0/)
