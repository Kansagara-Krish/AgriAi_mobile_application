import os
from pathlib import Path
from typing import Dict, Any, Optional
from reportlab.lib.pagesizes import letter
from reportlab.lib import colors
from reportlab.platypus import SimpleDocTemplate, Paragraph, Spacer, Table, TableStyle, Image as RLImage
from reportlab.lib.styles import getSampleStyleSheet, ParagraphStyle

from app.core.config import settings

class ReportService:
    """
    Generates professional PDF diagnostic reports for farmers and agronomists.
    """

    def __init__(self):
        self.styles = getSampleStyleSheet()
        self._setup_custom_styles()

    def _setup_custom_styles(self):
        self.title_style = ParagraphStyle(
            'DocTitle',
            parent=self.styles['Heading1'],
            fontSize=22,
            leading=26,
            textColor=colors.HexColor('#1B5E20'),
            spaceAfter=6
        )
        self.subtitle_style = ParagraphStyle(
            'DocSubtitle',
            parent=self.styles['Normal'],
            fontSize=11,
            leading=14,
            textColor=colors.HexColor('#4A7C59'),
            spaceAfter=15
        )
        self.section_heading = ParagraphStyle(
            'SectionHeading',
            parent=self.styles['Heading2'],
            fontSize=14,
            leading=18,
            textColor=colors.HexColor('#2E7D32'),
            spaceBefore=12,
            spaceAfter=6
        )
        self.body_style = ParagraphStyle(
            'Body',
            parent=self.styles['Normal'],
            fontSize=10,
            leading=14,
            textColor=colors.HexColor('#212121')
        )
        self.alert_style = ParagraphStyle(
            'Alert',
            parent=self.styles['Normal'],
            fontSize=10,
            leading=14,
            textColor=colors.HexColor('#C62828')
        )

    def generate_pdf_report(self, diagnosis_data: Dict[str, Any], output_filename: Optional[str] = None) -> Path:
        sample_id = diagnosis_data.get("sample_id", "SAMPLE")
        if not output_filename:
            output_filename = f"report_{sample_id}.pdf"

        report_path = settings.REPORTS_DIR / output_filename
        doc = SimpleDocTemplate(
            str(report_path),
            pagesize=letter,
            rightMargin=36,
            leftMargin=36,
            topMargin=36,
            bottomMargin=36
        )

        elements = []

        # 1. Header
        elements.append(Paragraph("🌿 AgriAI Agricultural Diagnostic Report", self.title_style))
        elements.append(Paragraph("Multimodal Leaf Disease & Soil Health Decision-Support System", self.subtitle_style))
        elements.append(Spacer(1, 10))

        # 2. Metadata Table
        meta_data = [
            [Paragraph("<b>Sample ID:</b>", self.body_style), Paragraph(str(sample_id), self.body_style),
             Paragraph("<b>Date / Time:</b>", self.body_style), Paragraph(str(diagnosis_data.get("timestamp", "N/A")), self.body_style)],
            [Paragraph("<b>Target Crop:</b>", self.body_style), Paragraph(str(diagnosis_data.get("crop", "N/A")), self.body_style),
             Paragraph("<b>Diagnosis Type:</b>", self.body_style), Paragraph(str(diagnosis_data.get("diagnosis_type", "Integrated")), self.body_style)],
            [Paragraph("<b>Risk Level:</b>", self.body_style), Paragraph(f"<b>{diagnosis_data.get('overall_risk_level', 'N/A')}</b>", self.body_style),
             Paragraph("<b>Paired Sample:</b>", self.body_style), Paragraph("Yes" if diagnosis_data.get("is_paired_sample") else "No / Untracked", self.body_style)]
        ]
        meta_table = Table(meta_data, colWidths=[100, 170, 100, 170])
        meta_table.setStyle(TableStyle([
            ('BACKGROUND', (0, 0), (-1, -1), colors.HexColor('#F1F8E9')),
            ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#C8E6C9')),
            ('PADDING', (0, 0), (-1, -1), 6),
            ('VALIGN', (0, 0), (-1, -1), 'MIDDLE')
        ]))
        elements.append(meta_table)
        elements.append(Spacer(1, 12))

        # 3. Leaf Disease Section
        leaf_disease = diagnosis_data.get("leaf_disease")
        if leaf_disease:
            elements.append(Paragraph("📷 Leaf Disease Vision Diagnosis", self.section_heading))
            conf = diagnosis_data.get("leaf_confidence", 0.0)
            leaf_text = f"<b>Identified Condition:</b> {leaf_disease} (Confidence: {conf:.1f}%)"
            elements.append(Paragraph(leaf_text, self.body_style))

            # Optional GradCAM image
            gradcam_fn = diagnosis_data.get("gradcam_filename")
            if gradcam_fn:
                gradcam_path = settings.UPLOADS_DIR / gradcam_fn
                if gradcam_path.exists():
                    elements.append(Spacer(1, 6))
                    elements.append(Paragraph("<b>Grad-CAM Explainable AI Heatmap:</b>", self.body_style))
                    elements.append(RLImage(str(gradcam_path), width=200, height=200))

            elements.append(Spacer(1, 10))

        # 4. Soil Health Section
        soil_status = diagnosis_data.get("soil_status")
        if soil_status:
            elements.append(Paragraph("🌱 Soil Health Analysis (XGBoost & SHAP)", self.section_heading))
            soil_conf = diagnosis_data.get("soil_confidence", 0.0)
            p_health = diagnosis_data.get("soil_p_healthy", 0.0)
            elements.append(Paragraph(f"<b>Status:</b> {soil_status} | <b>Healthy Probability:</b> {p_health:.2f} | <b>Confidence:</b> {soil_conf:.1f}%", self.body_style))

            shap_features = diagnosis_data.get("soil_shap_features", [])
            if shap_features:
                elements.append(Spacer(1, 4))
                elements.append(Paragraph("<b>Influential SHAP Soil Features:</b>", self.body_style))
                shap_rows = [["Feature", "Measured Value", "SHAP Impact", "Trend"]]
                for sf in shap_features[:5]:
                    shap_rows.append([
                        str(sf.get("feature")),
                        str(sf.get("measured_value")),
                        str(sf.get("shap_value")),
                        str(sf.get("direction"))
                    ])
                shap_table = Table(shap_rows, colWidths=[150, 110, 110, 170])
                shap_table.setStyle(TableStyle([
                    ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#E8F5E9')),
                    ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#C8E6C9')),
                    ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                    ('PADDING', (0, 0), (-1, -1), 4),
                    ('FONTSIZE', (0, 0), (-1, -1), 8)
                ]))
                elements.append(shap_table)

            elements.append(Spacer(1, 10))

        # 5. Agronomic Prescriptions & Advisories
        elements.append(Paragraph("📋 Prescribed Agronomic Interventions", self.section_heading))
        fert_prescriptions = diagnosis_data.get("fertilizer_prescriptions", [])
        if fert_prescriptions:
            elements.append(Paragraph("<b>Fertilizer & Soil Amendments:</b>", self.body_style))
            fert_rows = [["Type", "Recommended Chemical", "Dosage", "Farmer Advisory"]]
            for fp in fert_prescriptions:
                fert_rows.append([
                    Paragraph(str(fp.get("prescription_type")), self.body_style),
                    Paragraph(str(fp.get("recommended_chemical")), self.body_style),
                    Paragraph(str(fp.get("dosage")), self.body_style),
                    Paragraph(str(fp.get("advisory")), self.body_style)
                ])
            fert_table = Table(fert_rows, colWidths=[110, 130, 120, 180])
            fert_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#E0F2F1')),
                ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#B2DFDB')),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('PADDING', (0, 0), (-1, -1), 4),
                ('VALIGN', (0, 0), (-1, -1), 'TOP')
            ]))
            elements.append(fert_table)
            elements.append(Spacer(1, 8))

        prot_advisories = diagnosis_data.get("plant_protection_advisory", [])
        if prot_advisories:
            elements.append(Paragraph("<b>Plant Protection & Fungicide / Pest Control:</b>", self.body_style))
            prot_rows = [["Condition", "Chemical / Bio-Control", "Dosage", "Advisory"]]
            for pa in prot_advisories:
                prot_rows.append([
                    Paragraph(str(pa.get("target_condition")), self.body_style),
                    Paragraph(str(pa.get("recommended_protection")), self.body_style),
                    Paragraph(str(pa.get("dosage")), self.body_style),
                    Paragraph(str(pa.get("farmer_advisory")), self.body_style)
                ])
            prot_table = Table(prot_rows, colWidths=[110, 130, 120, 180])
            prot_table.setStyle(TableStyle([
                ('BACKGROUND', (0, 0), (-1, 0), colors.HexColor('#FFF3E0')),
                ('GRID', (0, 0), (-1, -1), 0.5, colors.HexColor('#FFE0B2')),
                ('FONTNAME', (0, 0), (-1, 0), 'Helvetica-Bold'),
                ('PADDING', (0, 0), (-1, -1), 4),
                ('VALIGN', (0, 0), (-1, -1), 'TOP')
            ]))
            elements.append(prot_table)
            elements.append(Spacer(1, 8))

        # 6. Summary & Warnings
        summary = diagnosis_data.get("agronomic_summary")
        if summary:
            elements.append(Paragraph("<b>Agronomic Synthesis:</b>", self.body_style))
            elements.append(Paragraph(summary, self.body_style))
            elements.append(Spacer(1, 6))

        warnings = diagnosis_data.get("warnings", [])
        if warnings:
            elements.append(Paragraph("<b>Safety Warnings & Alerts:</b>", self.body_style))
            for w in warnings:
                elements.append(Paragraph(w, self.alert_style))

        doc.build(elements)
        return report_path
