function transform(line) {
    values = line.split(',')

    var obj = new Object();
    var i = 0;
    var addr = ""
    
    obj.guid = values[i++];
    obj.isActive = Boolean(values[i++]);
    obj.firstname = values[i++];
    obj.surname = values[i++];
    obj.company = values[i++];
    obj.email = values[i++];
    obj.phone = values[i++];
    addr = values[i++];
    while(true){
        addr = addr + values[i++];
        if (values[i].search('"') > 0){
          addr = addr + values[i++];
          break;
        }
    }
    obj.address = addr
    obj.about = values[i++];
    obj.registered = (new Date(values[i++]));
    obj.latitude = parseFloat(values[i++]);
    obj.longitude = parseFloat(values[i++]);
    var jsonString = JSON.stringify(obj);

    return jsonString;
}

