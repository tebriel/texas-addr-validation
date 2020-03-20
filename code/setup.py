# Always prefer setuptools over distutils
from setuptools import setup, find_packages

# Arguments marked as "Required" below must be included for upload to PyPI.
# Fields marked as "Optional" may be commented out.

setup(
    name='validator',
    version='1.0.0',
    long_description_content_type='text/markdown',
    packages=find_packages(),

    entry_points={  # Optional
        'console_scripts': [
            # 'convert=converter:main',
        ],
    },
)
