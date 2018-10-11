package phylo;

/*
* PHIAL (Phylogenetic interactve annotation library)
* Written in 2018 by
*   David Damerell <david.damerell@sgc.ox.ac.uk>, Leonidas Koukouflis <leonidas.koukouflis@sgc.ox.ac.uk>,
*   Lihua Liu <liulihua1@gmail.com> Sefa Garsot <>
*   Brian Marsden <brian.marsden@sgc.ox.ac.uk> Matthieu Schapira <matthieu.schapira@utoronto.ca>
*
* To the extent possible under law, the author(s) have dedicated all copyright and related and neighboring rights to this
* software to the public domain worldwide. This software is distributed without any warranty. You should have received a
* copy of the CC0 Public Domain Dedication along with this software. If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
*/

class PhyloNewickParser{
    static var newLineReg = ~/\n/g;
    static var carLineReg = ~/\r/g;
    static var whiteSpaceReg = ~/\s/g;
    

    public function new (){

    }

    public function parse(newickString:String):PhyloTreeNode{
        newickString = whiteSpaceReg.replace(newickString, "");
        newickString = newLineReg.replace(newickString,"");
        newickString = carLineReg.replace(newickString, "");

        var rootNode : PhyloTreeNode;
        rootNode = new PhyloTreeNode();

        rootNode.newickString = newickString;

        var currentNode=rootNode;
        var a:String;

        var branch:Dynamic;
        var charArray=newickString.split('');
        var j=0;
        for(j in 0...charArray.length){
            var i=j;
            if(charArray[i]=='(' && charArray[i+1]=='('){
                // New child and the child is not a leaf
                var childNode=new PhyloTreeNode(currentNode, '', false, 0);
                currentNode=childNode;
            }else if( (charArray[i]=='(' && charArray[i+1]!='(' && charArray[i-1]!='/')
                    || (charArray[i] == ',' && charArray[i + 1] != '(')){

                // New child but the child is a leaf
                i++;

                var name='';
                while(charArray[i] != ':' && charArray[i] != ',' && (charArray[i] != ')' || (charArray[i] == ')' && charArray[i-1] == '/'))){
                    //we need to check if = /
                    var p=charArray[i];
                    if((charArray[i] == '/')&&((charArray[i+1] == '[')||(charArray[i+1] == '('))) i++; //we just need to skip it and not check the next character.
                    if(charArray[i]=='[') name+='(';
                    else if (charArray[i]==']')  name+=')';
                    else name+=charArray[i];
                    i++;
                }

                if(charArray[i]==':'){
                    i++;

                    branch='';

                    while(charArray[i] != ',' && (charArray[i] != ')' || (charArray[i] == ')' && charArray[i-1] == '/')) && charArray[i] != ';'){
                        branch+=charArray[i];
                        i++;
                    }

                    i--;

                    branch=Std.parseFloat(branch);
                }else{
                    branch=1;
                }

                var child=new PhyloTreeNode(currentNode, name, true, branch);
            }else if(charArray[i]==',' && charArray[i+1]=='('){
                // more children that are not leaves
                var child=new PhyloTreeNode(currentNode, '', false, 0);
                currentNode=child;
            }else if(charArray[i]==')' && charArray[i-1]!='/'){
                // no more children
                if(charArray[i+1]==':'){
                    i+=2;
                    branch='';
                    while(charArray[i]!=',' && (charArray[i]!=')' || (charArray[i]==')'&& charArray[i-1]!='/'))&& charArray[i]!=';'){
                       branch+=charArray[i];
                       i++;
                    }

                    i--;
                    currentNode.branch=Std.parseFloat(branch);
                }
                currentNode=currentNode.parent;
            }
        }
        if(currentNode==null){
            return rootNode;
        }
        else return currentNode;
    }
}