package tasks;

import ceramic.Files;
import ceramic.Task;
import ceramic.Path;

using StringTools;

class FormatHaxeFiles extends Task {

    override function run() {

        var roots = [
            '/Users/jeremyfa/Developer/ceramic/runtime/src',
            '/Users/jeremyfa/Developer/ceramic/plugins'
        ];
        for (root in roots) {
            var paths = Files.getFlatDirectory(root);
    
            for (path in paths) {
                
                if (!path.endsWith('.hx'))
                    continue;

                var fullPath = Path.join([root, path]);
                var content = Files.getContent(fullPath);
                var prevContent = content;
                content = convertIndentationsToSpaces(content);
                content = formatComments(content, '');
                content = formatComments(content, '    ');
                if (content != prevContent) {
                    log.info('Save $fullPath');
                    Files.saveContent(fullPath, content);
                }
            }
        }

        done();

    }

    function convertIndentationsToSpaces(content:String) {

        var lines = content.replace('\r', '').split('\n');

        // Convert indentation tabs to spaces
        for (i in 0...lines.length) {
            var line = lines[i];
            var theIndent = line.substring(0, line.length - line.ltrim().length);
            theIndent = theIndent.replace('\t', '    ');
            line = theIndent + line.ltrim();
            lines[i] = line;
        }

        return lines.join('\n');

    }

    function formatComments(content:String, indent:String) {

        var lines = content.replace('\r', '').split('\n');

        // Iterate over lines to process (multiline) comments
        var output = [];
        var currentComment = null;
        for (line in lines) {
            var originalLine = line;
            if (currentComment == null) {
                if (line.startsWith('$indent/**')) {
                    line = line.substring(3 + indent.length);
                    if (line.startsWith(' '))
                        line = line.substring(1);
                    var closes = line.rtrim().endsWith('*/');
                    if (closes) {
                        line = line.rtrim().substring(0, line.rtrim().length - 2);
                        if (line.endsWith('*'))
                            line = line.substring(0, line.length - 1);
                        if (line.endsWith(' '))
                            line = line.substring(0, line.length - 1);
                    }
                    if (line.trim() != '') {
                        currentComment = [];
                        currentComment.push(line);
                    }
                    else {
                        // Ignore comment, seems fine
                        output.push(originalLine);
                    }
                    if (closes) {
                        output.push('$indent/**');
                        for (line in currentComment) {
                            output.push('$indent * ' + line);
                        }
                        output.push('$indent */');
                        currentComment = null;
                    }
                }
                else {
                    output.push(originalLine);
                }
            }
            else {
                if (line.rtrim().endsWith('*/')) {
                    
                    line = line.rtrim().substring(0, line.rtrim().length - 2);
                    if (line.endsWith('*'))
                        line = line.substring(0, line.length - 1);
                    if (line.endsWith(' '))
                        line = line.substring(0, line.length - 1);
                    if (line.trim() != '') {
                        currentComment.push(line.substring(4));
                    }

                    // Fix indentation
                    if (currentComment.length > 1) {
                        var i = currentComment.length - 1;
                        var oneMoreIndent = true;
                        while (i > 0) {
                            var line = currentComment[i];
                            if (!line.startsWith('    '))
                                oneMoreIndent = false;
                            i--;
                        }
                        if (oneMoreIndent) {
                            i = currentComment.length - 1;
                            while (i > 0) {
                                currentComment[i] = currentComment[i].substring(4);
                                i--;
                            }
                        }
                    }

                    output.push('$indent/**');
                    for (subline in currentComment) {
                        output.push('$indent * ' + subline);
                    }
                    output.push('$indent */');

                    currentComment = null;
                }
                else {
                    currentComment.push(originalLine.substring(4));
                }
            }
        }

        return output.join('\n');

    }

}