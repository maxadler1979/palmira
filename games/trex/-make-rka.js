

fso = new ActiveXObject("Scripting.FileSystemObject");
function fileSize(name) { return fso.GetFile(name).Size; }
function loadAll(name) { return fso.OpenTextFile(name, 1, false, 0).Read(fileSize(name)); } // File.LoadAll ������ 
function save(fileName, data) { fso.CreateTextFile(fileName).Write(data); }
src = loadAll("tbl.bin"); encode = []; decode = []; for(i=0; i<256; i++) { encode[i] = src.charAt(i); decode[src.charCodeAt(i)] = i; }

// ������ ����������� ����� �����

function apogeySum(data) {
  var s = 0;
  for(var i=0; i<data.length-1; i++)
    s += decode[data.charCodeAt(i)] * 257;
  s = (s & 0xFF00) + ((s + decode[data.charCodeAt(i)]) & 0xFF);
  return (s & 0xFFFF);
}


start = 0x0000;
data = loadAll("a.bin");
crc = apogeySum(data);
end = start+data.length-1;
save("trex.rk", encode[start>>8]+encode[start&0xFF]+encode[end>>8]+encode[end&0xFF]+data
                +encode[0]+encode[0]+encode[0]+encode[0xE6]+encode[crc>>8]+encode[crc&0xFF]);