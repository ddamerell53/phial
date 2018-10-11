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

class PhyloInputModalWidget extends PhyloGlassPaneWidget{
    public var message  : String;
    public var initialValue : String;
    public var textArea : Dynamic;

    public function new(parent : Dynamic, message : String, title : String, initialValue : String) {
        this.message = message;
        this.initialValue = initialValue;

        super(parent, title);
    }

    override public function addContent(){
        super.addContent();

        addMessage();

        addInputField();
    }

    public function addMessage(){
        var p = js.Browser.document.createElement('p');
        p.innerText = message;

        content.appendChild(p);
    }

    public function addInputField(){
        textArea = js.Browser.document.createElement('textarea');
        textArea.value = initialValue;
        textArea.style.width = '100%';
        textArea.setAttribute('rows','10');

        content.appendChild(textArea);
    }

    public function getText() : String{
        return textArea.value;
    }
}
