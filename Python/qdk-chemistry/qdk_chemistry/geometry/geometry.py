# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

"""Module that defines the Geometry and Element classes for keeping track of XYZ data 
for molecules
"""

import re
from dataclasses import dataclass
from typing import List, Tuple, Union, TYPE_CHECKING

from qdk_chemistry.geometry.rdkit_convert import _mol_to_coordinates
from qdk_chemistry.geometry.xyz import coordinates_to_xyz, element_coords_to_xyz

from rdkit.Chem import AllChem as Chem

if TYPE_CHECKING:
    from rdkit.Chem import Mol

FLOAT_PATTERN = "([+-]?[0-9]*[.][0-9]+)"
XYZ_PATTERN = f"(\w) {FLOAT_PATTERN} {FLOAT_PATTERN} {FLOAT_PATTERN}"

@dataclass
class Element:
    """Class for keeping track of element XYZ coordinates 
    for molecule geometry
    """
    name: str
    x: float
    y: float
    z: float

    @classmethod
    def from_tuple(cls, value: Tuple[str, float, float, float]):
        """Classmethod for constructing an Element instance from element coordinates

        :param value: Tuple with values (element name, x coordinate, y coordinate, z coordinate)
        :type value: Tuple[str, float, float, float]
        :return: Element instance
        :rtype: Element
        """
        name, x, y, z = value
        return cls(name=name, x=float(x), y=float(y), z=float(z))

    def to_xyz(self):
        return element_coords_to_xyz(
            name=self.name,
            x=self.x,
            y=self.y,
            z=self.z
        )


class Geometry(List[Element]):
    """Molecular geometry consisting of list of elements with
    XYZ coordinates
    """
    def __init__(self, *args, charge: Union[int, None] = None, **kwargs):
        self.charge = charge
        super().__init__(*args, **kwargs)

    @property
    def coordinates(self) -> Tuple[str, float, float, float]:
        """Get coordinates list of tuples (name, x, y, z)

        :return: List of coordinate tuples
        :rtype: Tuple[str, float, float, float]
        """
        for element in self:
            yield ( element.name, element.x, element.y, element.z )

    @classmethod
    def from_mol(cls, mol: "Mol", num_confs: int = 10):
        """Classmethod for constructing a geometry instance from an RDKit molecule 
        object

        :param mol: RDKit molecule object
        :type mol: Mol
        :param num_confs: Number of molecular conformers to generate, defaults to 10
        :type num_confs: int, optional
        """
        # This returns a plain list of tuples (element name, x, y, z)
        coordinates = _mol_to_coordinates(
            mol=mol,
            num_confs=num_confs
        )
        charge = Chem.GetFormalCharge(mol)

        return cls(
            [
                Element(name=name, x=x, y=y, z=z)
                for (name, x, y, z) in coordinates
            ], 
            charge=charge
        )
    
    @classmethod
    def from_xyz(cls, xyz: str):
        """Generate geometry portion of NWChem file from XYZ data.
        The formatting of the .xyz file format is as follows:

            <number of atoms>
            comment line
            <element> <X> <Y> <Z>
            ...

        Source: https://en.wikipedia.org/wiki/XYZ_file_format.

        :param xyz: XYZ file format
        :type xyz: str
        """
        if "\n" not in xyz:
            return cls([])

        num_atoms = re.match("\s*(?P<num_atoms>\d+)\s*\n", xyz)
        match = re.findall(XYZ_PATTERN, xyz)
        assert num_atoms is not None and len(match) == int(num_atoms.group("num_atoms")), f"Invalid XYZ file: \
            number of atoms {num_atoms} does not match number of elements found {len(match)}"
        return cls([Element.from_tuple(item) for item in match])

    def to_xyz(self, title: str = "unnamed"):
        """Convert geometry to XYZ-formatted string

        :param title: XYZ file title
        :type title: str
        :returns: XYZ-formatted string
        :rtype: str
        """
        return coordinates_to_xyz(
            number_of_atoms=len(self),
            charge=self.charge,
            coordinates=self.coordinates,
            title=title
        )


def format_geometry(geometry: Geometry, line_sep: str="\n") -> str:
    """Format geometry into text format

    Example:
    <Element> <x> <y> <x>

    :param geometry: Geometry object
    :type geometry: Geometry
    :param line_sep: Line separator, defaults to "\n"
    :type line_sep: str
    :return: Geometry in text format, each element separated by given separator
    :rtype: str
    """
    return line_sep.join(el.to_xyz() for el in geometry)


def format_geometry_from_mol(mol: "Mol", line_sep: str = "\n") -> str:
    """Get geometry in text format from RDKit molecule object

    :param mol: RDKit molecule
    :type mol: Mol
    :param line_sep: Line separator, defaults to "\n"
    :type line_sep: str
    """
    g = Geometry.from_mol(mol)
    return format_geometry(geometry=g, line_sep=line_sep)


def format_geometry_from_xyz(xyz: str, line_sep: str = "\n") -> str:
    """Generate geometry text format from XYZ data.
    The formatting of the .xyz file format is as follows:

        <number of atoms>
        comment line
        <element> <X> <Y> <Z>
        ...

    Source: https://en.wikipedia.org/wiki/XYZ_file_format.

    :param xyz: XYZ file format
    :type xyz: str
    :param line_sep: Line separator, defaults to "\n"
    :type line_sep: str
    :return: Geometry in text format
    :rtype: str
    """
    g = Geometry.from_xyz(xyz)
    return format_geometry(geometry=g, line_sep=line_sep)
