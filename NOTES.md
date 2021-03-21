* the mapping CoMID--measurements depends on update/patch granularity of SW components
  * 1 CoMID per SW component if you want to be able to update SW components independently
    * CoMID roughly OK; maybe we should evaluate the advantages of having an extension point in the element-value (rather than in the reference-value) to add metadata related to the measurement "closer" to the measurement -- SUGAR requirement
  * 1 CoMID per bundle of SW components if you update always in block
    * CoMID nearly OK.  The only annoying thing is having to restate the same element-name that is anyway already in the top-level module meta...


* how to flag a security critical update / patch?
  * options:
    * extend linked tag entry
    * extend tag-rel-type to accept "parameters / flags"
