String.prototype.title_case = () ->
  this.replace(/\w\S*/g, (txt) -> txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase())

Array.prototype.join_and = (sep=', ', sep_and=' and ') ->
  outStr = ''
  if this.length == 1
    outStr = this[0]
  else if this.length == 2
    outStr = this.join(sep_and);
  else if this.length > 2
    # if sep[-1] == sep_and[0] then it is a redundant character, most likely a space.
    if sep.length > 0 and sep_and.length > 0 and sep[sep.length - 1] == sep_and[0]
      sep_and = sep_and.slice(1, sep_and.length)

    outStr = this.slice(0, -1).join(sep) + "#{sep}#{sep_and}" + this.slice(-1)
  outStr
