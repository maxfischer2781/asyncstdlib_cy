from setuptools import setup, Extension
from pathlib import Path


def module_name(path: Path):
    return str(path.with_suffix("")).replace("/", ".")


package = "asyncstdlib_cy"


setup(
    name=package,
    version="0.0.1",
    author="Max Fischer",
    author_email="maxfischer2781@gmail.com",
    url="https://github.com/maxfischer2781/asyncstdlib_cy",
    description="Cython acceleration for asyncstdlib",
    long_description="Experimental!",
    keywords="asyncstdlib async cython",
    classifiers=[
        "Framework :: AsyncIO",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python :: 3",
    ],
    install_requires=[
        "asyncstdlib",
        "typing_extensions; python_version<'3.8'",
    ],
    packages=[package],
    package_dir={"": "src"},
    ext_modules=[
        Extension(module_name(extension), [str(extension)])
        for extension in Path(package).glob("*.pyx")
    ],
    include_package_data=True,
    package_data={"": ["*.pxd"]},
)
