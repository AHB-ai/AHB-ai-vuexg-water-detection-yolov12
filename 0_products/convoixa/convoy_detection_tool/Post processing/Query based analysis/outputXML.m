function outputXML(input, output_dir)
docNode = com.mathworks.xml.XMLUtils.createDocument...
    ('ANPR_BOOK');
docRootNode = docNode.getDocumentElement;
filename =[input{1,1}{1,1} ' ' input{1,1}{2,1}];
for i=1:length(input)
    val = input{i};
    [m,~] = size(val);
    entryElement = docNode.createElement('Entry');
    regElement = docNode.createElement('RegNum');
    timeElement = docNode.createElement('Time');
    for j=1:m
        timestamp = val{j,2};
        subTimeElement = docNode.createElement('time');
        subTimeElement.appendChild...
            (docNode.createTextNode(sprintf(timestamp)));
        timeElement.appendChild(subTimeElement);
    end
    anprElement = docNode.createElement('ANPR');
    for n=1:m
        anprstamp = val{n,3};
        subAnprElement = docNode.createElement('anpr');
        subAnprElement.appendChild...
            (docNode.createTextNode(sprintf(anprstamp)));
        anprElement.appendChild(subAnprElement);
    end
    entryElement.appendChild(regElement);
    entryElement.appendChild(timeElement);
    entryElement.appendChild(anprElement);
    regstamp = [val{1,1} ' ' val{2,1}];
    regElement.appendChild...
        (docNode.createTextNode(sprintf(regstamp)));
    docRootNode.appendChild(entryElement);
end
xmlFileName = [output_dir '/' filename,'.xml'];
xmlwrite(xmlFileName,docNode);
type(xmlFileName);
end