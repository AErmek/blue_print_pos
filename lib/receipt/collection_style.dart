class CollectionStyle {
  CollectionStyle._();

  /// Getter for all css style pre-define
  static String get all {
    return '''
      <style>
          body,
          p {
              margin: 0px;
              padding: 0px;
              font-family: helvetica; 
          }
          
          body {
              background: #eee;
              width: 586px;
              font-size: 28px;
              margin: 0px;
              padding: 0px;
              text-align: justify;  
          }
          
          .receipt {
              max-width: 586px;
              margin: 0px;
              background: white;
          }
          
          .container {
              margin: 0px;
              padding: 0px;
          }
          
          hr {
              border-top: 2px dashed black;
          }
          
          .text-center {
              text-align: center;
          }
          
          .text-left {
              text-align: left;
          }
          
          .text-right {
              text-align: right;
          }
          
          .text-justify {
              text-align: justify;
          }
          
          .right {
              float: right;
          }
          
          .left {
              float: left;
          }
          
          span {
              color: black;
              font-family: helvetica;
          }
          
          .full-width {
              width: 100%;
          }
          
          .inline-block {
              display: inline-block;
          }
          
          .text-extra-large {
              font-size: 2.2em;
          }
          
          .text-large {
              font-size: 1.6em;
          }
          
          .text-medium {
              font-size: 28px;
              text-align: justify;
              border: 1px solid blue;
          }
          
          .text-small {
              font-size: 0.8em;
          }
      </style>
    ''';
  }

  /// To separate style from all css, just create getter the value of style name
  static String get textCenter => 'text-center';
  static String get textLeft => 'text-left';
  static String get textRight => 'text-right';
}
