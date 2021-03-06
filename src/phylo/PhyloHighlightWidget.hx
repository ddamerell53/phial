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

class PhyloHighlightWidget extends PhyloGlassPaneWidget {
    public var highlightInputs : Array<Dynamic>;
    public var canvas : PhyloCanvasRenderer;

    public function new(parent : Dynamic, canvas : PhyloCanvasRenderer) {
        this.canvas = canvas;

        super(parent,'Select genes to highlight in tree', true);
    }

    override public function onClose(){
        canvas.getConfig().highlightedGenes=new Map<String, Bool>();

        for(inputElement in highlightInputs){
            if(inputElement.checked){
                canvas.getConfig().highlightedGenes.set(inputElement.getAttribute('value'), true);
            }
        }

        canvas.redraw();
    }

    override public function addContent(){
        super.addContent();

        addHighlightList();
    }

    public function addHighlightList(){
        var formContainer = js.Browser.document.createElement('div');
        formContainer.setAttribute('id', 'highlight-box');
        formContainer.style.margin = 'auto';
        formContainer.style.overflowY = 'scroll';
        formContainer.style.height = '75%';

        highlightInputs = new Array<Dynamic>();

        var targets = canvas.getRootNode().targets;

        targets.sort(function(a, b) {
            var targetA = a.toUpperCase();
            var targetB = b.toUpperCase();
            return (targetA < targetB) ? -1 : (targetA > targetB) ? 1 : 0;
        });

        var i = 0;
        for(target in targets){
            if(target == null || target == ''){
                continue;
            }

            i += 1;

            var elementWrapper = js.Browser.document.createElement('div');
            elementWrapper.setAttribute('class', 'element-wrapper');
            elementWrapper.style.float = 'left';
            elementWrapper.style.marginRight = '28px';
            elementWrapper.style.marginBottom = '10px';

            var name = 'target_highlight_' + i;

            var inputLabel = js.Browser.document.createElement('label');
            inputLabel.setAttribute('for', name);
            inputLabel.innerText = target;
            inputLabel.style.float = 'left';
            inputLabel.style.width = '55px';
            inputLabel.style.margin = '0';

            var inputElement = js.Browser.document.createElement('input');
            inputElement.setAttribute('type', 'checkbox');
            inputElement.setAttribute('value', target);
            inputElement.setAttribute('name', name);
            inputElement.style.width = '15px';
            inputElement.style.height = '15px';
            inputElement.style.margin = '1px';

            highlightInputs.push(inputElement);

            formContainer.appendChild(elementWrapper);
            elementWrapper.appendChild(inputLabel);
            elementWrapper.appendChild(inputElement);


            /**
            if(i % 7 == 0){
                formContainer.appendChild(js.Browser.document.createElement('br'));
            } */
        }

        content.appendChild(formContainer);
    }
}
