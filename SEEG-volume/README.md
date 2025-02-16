# SEEG-volume

This script is used to convert a SEEG electrode to a volume mask. 
The mask value is 1 near specfied SEEG contacts and 0 elsewhere. 


# Inputs

- Subject Name 
- Path to the SEEG electrode channel file
- Contact Name: name of the contact names to use for the mask
- Radius: radius to consider around each of the contact, in mm 
- Output Name: Name for the mask output

# Output

- 3D volume stored in the brainstorm database. Name specified by the input
Output Name. 


See example.m to see how to call the function. 
