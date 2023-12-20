## STEMMUS_SCOPE BMI

`STEMMUS_SCOPE` has a BMI-like interface. This is available when running the Matlab Runtime version of the model.
The full BMI is implemented in Python in [PyStemmusScope](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/).

A Docker image will also be available, which allows you to run the model on any system without installing Matlab Runtime.

### BMI mode

When starting the executable, a run-mode can be specified. The following command will run the model using the config file:

```sh
./STEMMUS_SCOPE "/home/path/to/config/file.txt" full
```

(Where `./STEMMUS_SCOPE` is the path to the executable. For more info see)

To start BMI mode, pass anything (e.g. an empty string "") as config file, and use `bmi` to start the model in BMI-mode:

```sh
./STEMMUS_SCOPE "" bmi
```

The model will respond with `Finished command. Select run mode: `. Now you can initialize the mode:

```
Finished command. Select run mode: interactive "/home/path/to/config/file.txt"
```

The model will respond with:
```
Reading config from /home/path/to/config/file.txt
Finished model initialization
```

Now you can use the commands `update` to advance the model by one timestep, and `finalize` to finalize the model.

### Updating exposed variables

The variables which are exposed to the Python BMI are defined in `STEMMUS_SCOPE_exe.m`.
To add more variables, update the `bmiVarNames` variable.
After this, you will need to update the BMI in [PyStemmusScope](https://github.com/EcoExtreML/STEMMUS_SCOPE_Processing/) so it can make use of these exposed variables.
