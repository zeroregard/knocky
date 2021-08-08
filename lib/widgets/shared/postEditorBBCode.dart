import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:knocky/helpers/bbcodehelper.dart';

class PostEditorBBCode extends StatefulWidget {
  final Function onInputChange;
  final TextEditingController textEditingController;
  PostEditorBBCode({this.onInputChange, this.textEditingController});
  @override
  _PostEditorBBCodeState createState() => _PostEditorBBCodeState();
}

class _PostEditorBBCodeState extends State<PostEditorBBCode> {
  @override
  void initState() {
    super.initState();
  }

  Widget btn(String tooltip, IconData icon, Function onPressed) {
    return IconButton(
        tooltip: tooltip,
        padding: EdgeInsets.all(4),
        splashRadius: 16,
        icon: Icon(icon, size: 16),
        onPressed: onPressed,
        visualDensity: VisualDensity.compact);
  }

  Widget toolbar(BuildContext context) {
    var addTag = (tag) => BBCodeHelper.addTagAtSelection(
        widget.textEditingController, tag, widget.onInputChange);
    var buttons = [
      btn('Bold', FontAwesomeIcons.bold, () => addTag.call('b')),
      btn('Italic', FontAwesomeIcons.italic, () => addTag.call('i')),
      btn('Underline', FontAwesomeIcons.underline, () => addTag.call('u')),
      btn('Strikethrough', FontAwesomeIcons.strikethrough,
          () => addTag.call('u')),
      btn('Code', FontAwesomeIcons.code, () => addTag.call('code')),
      btn('Spoiler', FontAwesomeIcons.solidEyeSlash,
          () => addTag.call('spoiler')),
      btn('H1', FontAwesomeIcons.heading, () => addTag.call('h1')),
      btn('H2', FontAwesomeIcons.font, () => addTag.call('h2')),
      btn('Quote', FontAwesomeIcons.quoteRight,
          () => addTag.call('blockquote')),
      btn('Unordered list', FontAwesomeIcons.listUl, () => addTag.call('ul')),
      btn('Ordered list', FontAwesomeIcons.listOl, () => addTag.call('ol')),
      // TODO: remaining buttons
    ];
    return Container(
        color: Theme.of(context).primaryColor, child: Wrap(children: buttons));
  }

  Widget editor(BuildContext context) {
    return Expanded(
        child: TextField(
      controller: widget.textEditingController,
      textInputAction: TextInputAction.newline,
      maxLines: null,
      expands: true,
      onChanged: this.widget.onInputChange,
      decoration:
          InputDecoration(contentPadding: EdgeInsets.fromLTRB(8, 8, 8, 8)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[editor(context), toolbar(context)]);
  }
}