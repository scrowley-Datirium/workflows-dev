cwlVersion: v1.0
class: CommandLineTool


requirements:
- class: ShellCommandRequirement
- class: InlineJavascriptRequirement
  expressionLib:
  - var get_output_filename = function(ext) {
        ext = ext || "";
        if (inputs.output_filename == null){
          var root = inputs.rsem_isoforms_file.basename.split('.').slice(0,-1).join('.');
          return (root == "")?inputs.rsem_isoforms_file.basename+ext:root+ext;
        } else {
          return inputs.output_filename;
        }
    };


hints:
- class: DockerRequirement
  dockerPull: biowardrobe2/scidap:v0.0.3


inputs:

  script:
    type: string?
    default: |
      #!/usr/bin/env python
      import sys
      opts = {
          2: lambda l : l.strip(),
          3: lambda l : l.strip().split()[0],
          4: lambda l : [str(int(l.strip().split()[1])-1), l.strip().split()[-1]]
      }
      print "RefseqId,GeneId,Chrom,TxStart,TxEnd,Strand,TotalReads,Rpkm"
      with open(sys.argv[1], 'r') as iso_stream, open(sys.argv[2], 'r') as anno_stream:
          iso_stream.readline()
          anno_stream.readline()
          for iso_line in iso_stream:
              iso_list = iso_line.strip().split('\t')
              result = []
              for idx in range(6):
                  anno_line = anno_stream.readline().strip()
                  if idx in opts.keys(): result.append(opts[idx](anno_line))
              print ','.join( [iso_list[0],iso_list[1],result[0],result[2][0],result[2][1],result[1],iso_list[4],iso_list[6]])
    inputBinding:
      position: 5
    doc: |
      Python script to generate BioWardrobe compatible isforoms file from RSEM outputs

  rsem_isoforms_file:
    type: File
    inputBinding:
      position: 6
    doc: |
      Generated by RSEM isoform file

  rsem_annotation_file:
    type: File
    inputBinding:
      position: 7
    doc: |
      *.ti file from RSEM indices folder to include sorted information about processed isoforms

  output_filename:
    type: string?
    doc: |
      Name for output file


outputs:

  biowardrobe_isoforms_file:
    type: File
    outputBinding:
      glob: "*"


baseCommand: [python, '-c']
arguments:
  - valueFrom: $(" > " + get_output_filename(".csv"))
    position: 100000
    shellQuote: false


$namespaces:
  s: http://schema.org/

$schemas:
- http://schema.org/version/9.0/schemaorg-current-http.rdf

s:name: "python-make-biowardrobe-isoforms"
s:downloadUrl: https://raw.githubusercontent.com/Barski-lab/workflows/master/tools/python-make-biowardrobe-isoforms.cwl
s:codeRepository: https://github.com/Barski-lab/workflows
s:license: http://www.apache.org/licenses/LICENSE-2.0

s:isPartOf:
  class: s:CreativeWork
  s:name: Common Workflow Language
  s:url: http://commonwl.org/

s:creator:
- class: s:Organization
  s:legalName: "Cincinnati Children's Hospital Medical Center"
  s:location:
  - class: s:PostalAddress
    s:addressCountry: "USA"
    s:addressLocality: "Cincinnati"
    s:addressRegion: "OH"
    s:postalCode: "45229"
    s:streetAddress: "3333 Burnet Ave"
    s:telephone: "+1(513)636-4200"
  s:logo: "https://www.cincinnatichildrens.org/-/media/cincinnati%20childrens/global%20shared/childrens-logo-new.png"
  s:department:
  - class: s:Organization
    s:legalName: "Allergy and Immunology"
    s:department:
    - class: s:Organization
      s:legalName: "Barski Research Lab"
      s:member:
      - class: s:Person
        s:name: Michael Kotliar
        s:email: mailto:misha.kotliar@gmail.com
        s:sameAs:
        - id: http://orcid.org/0000-0002-6486-3898

doc: |
  Tool to generate BioWardrobe compatible isoforms file from RSEM outputs.
  `rsem_annotation_file` and `rsem_isoforms_file` are supposed to have identical order and number of isoforms.
  FPKM value is used intead of RPKM.

s:about: |
  Runs python code from the `script` input
