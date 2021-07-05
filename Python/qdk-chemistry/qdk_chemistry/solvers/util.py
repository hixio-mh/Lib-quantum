import warnings

from typing import Union, TYPE_CHECKING

from qdk_chemistry.geometry import Geometry, format_geometry, format_geometry_from_mol

if TYPE_CHECKING:
    from rdkit.Chem.AllChem import Mol


def num_atoms_from_mol(mol: "Mol") -> int:
    """Calculate the number of atoms in the molecule

    :param mol: RDKit molecule object
    :type mol: Mol
    :return: Number of atoms or sum of atomic number of atoms in molecule
    :rtype: int
    """
    return len(mol.GetAtoms())


def num_electrons(mol: "Mol") -> int:
    """Calculate the number of electrons in the molecule

    :param mol: RDKit molecule object
    :type mol: Mol
    :return: Number of electrons or sum of atomic number of atoms in molecule
    :rtype: int
    """
    return sum([atom.GetAtomicNum() for atom in mol.GetAtoms()])


def formatted_geometry_str(
    mol: "Mol", 
    geometry: Union[str, Geometry] = None,
    line_sep: str = "\n") -> str:
    """Format geometry for input deck

    :param mol: Molecule object
    :type mol: Mol, optional
    :param geometry: Geometry object or string, defaults to None
    :type geometry: Union[str, Geometry], optional
    :param line_sep: Line separator, defaults to "\n"
    :type line_sep: str
    :return: Formatted geometry string
    :rtype: str
    """
    if geometry is None:
        geometry = format_geometry_from_mol(mol=mol, line_sep=line_sep)
    else:
        warnings.warn("Ignoring mol and using specified geometry string instead.")

        if isinstance(geometry, Geometry):
            geometry = format_geometry(geometry=geometry, line_sep=line_sep)

    return geometry
