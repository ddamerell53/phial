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

class PhyloImportWidget {
    var canvas : PhyloCanvasRenderer;
    var container : Dynamic;

    public function new(canvas : PhyloCanvasRenderer) {
        this.canvas = canvas;

        build();
    }

    public function build(){
        addContainer();
    }

    public function getContainer() : Dynamic {
        return container;
    }

    public function addContainer(){
        container = js.Browser.document.createElement('div');

        container.style.display = 'inline-block';
        container.style.minWidth = '160px';
        container.style.position = 'relative';
        container.style.verticalAlign = 'top';
        container.style.backgroundColor = '#f7f8fb';
        container.marginLeft = '0px';
        container.marginTop = '0px';

        container.innerHTML = '<h1 style="margin-left:5px;margin-right:5px">Import</h1>';

        addButtons();
    }

    public function addButtons(){
        addImportNewickButton();
        addImportAnnotationsButton();

        if(canvas.getConfig().enableFastaImport){
            addGenerateFromFASTAButton();
        }
    }

    public function addImportNewickButton(){
        var btn = js.Browser.document.createElement('button');
        btn.innerText = 'Import Newick';
        btn.style.backgroundColor = 'rgb(247, 248, 251)';
        btn.style.border = 'none';
        btn.style.font = 'normal 11px/16px tahoma, arial, verdana, sans-serif';
        btn.style.cursor = 'pointer';
        btn.style.textAlign = 'left';
        btn.style.width = '100%';
        btn.setAttribute('title', 'ImportNewick');

        btn.addEventListener('mouseover', function(){
            btn.style.backgroundColor = '#dddee1';
        });

        btn.addEventListener('mouseout', function(){
            btn.style.backgroundColor = 'rgb(247, 248, 251)';
        });

        btn.addEventListener('click', function(){
            var dialog = new PhyloInputModalWidget(js.Browser.document.body, 'Newick String','Enter newick string', canvas.getRootNode().getNewickString());

            dialog.setOnCloseEvent(updateTree);
        });

        container.appendChild(btn);
    }

    public function updateTree(dialog :PhyloInputModalWidget){
        canvas.setNewickString(dialog.getText());
    }

    public function addImportAnnotationsButton(){
        var btn = js.Browser.document.createElement('button');
        btn.innerText = 'Import Annotations';
        btn.style.backgroundColor = 'rgb(247, 248, 251)';
        btn.style.border = 'none';
        btn.style.font = 'normal 11px/16px tahoma, arial, verdana, sans-serif';
        btn.style.cursor = 'pointer';
        btn.style.textAlign = 'left';
        btn.style.width = '100%';
        btn.setAttribute('title', 'ImportNewick');

        btn.addEventListener('mouseover', function(){
            btn.style.backgroundColor = '#dddee1';
        });

        btn.addEventListener('mouseout', function(){
            btn.style.backgroundColor = 'rgb(247, 248, 251)';
        });

        btn.addEventListener('click', function(){
            var dialog = new PhyloInputModalWidget(js.Browser.document.body, 'Annotations in CSV format (first column is gene name)','Enter Annotations', canvas.getAnnotationManager().getAnnotationString());

            dialog.setOnCloseEvent(updateAnnotations);
        });

        container.appendChild(btn);
    }

    public function updateAnnotations(dialog : PhyloInputModalWidget){
        canvas.getAnnotationManager().loadAnnotationsFromString(dialog.getText(), canvas.getAnnotationManager().getAnnotationConfigs());
    }

    public function addGenerateFromFASTAButton(){
        var btn = js.Browser.document.createElement('button');
        btn.innerText = 'Import FASTA';
        btn.style.backgroundColor = 'rgb(247, 248, 251)';
        btn.style.border = 'none';
        btn.style.font = 'normal 11px/16px tahoma, arial, verdana, sans-serif';
        btn.style.cursor = 'pointer';
        btn.style.textAlign = 'left';
        btn.style.width = '100%';
        btn.setAttribute('title', 'Import Fasta');

        btn.addEventListener('mouseover', function(){
            btn.style.backgroundColor = '#dddee1';
        });

        btn.addEventListener('mouseout', function(){
            btn.style.backgroundColor = 'rgb(247, 248, 251)';
        });

        btn.addEventListener('click', function(){
            var dialog = new PhyloInputModalWidget(js.Browser.document.body, 'FASTA format','Enter sequences', canvas.getRootNode().getFasta());

            dialog.setOnCloseEvent(updateFASTA);
        });

        container.appendChild(btn);
    }

    public function updateFASTA(dialog : PhyloInputModalWidget){
        canvas.setFromFasta(dialog.getText());
    }
}
